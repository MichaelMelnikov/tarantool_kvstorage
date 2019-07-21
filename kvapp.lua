#!/usr/bin/env tarantool

-- log ------------------------------------------------------------------------
box.cfg{ listen = 3301, log_level=5, log='kv_db.txt' }
log = require('log')

-- create db ------------------------------------------------------------------
createDB = function()
    dbspace = box.schema.space.create('db')
    log.info('db space created')
    -- create primary key
    dbspace:create_index('primary', {type = 'hash', parts = {1, 'string'}}) 
    log.info('db space primary index created')
end
-- admin stuff
box.schema.user.passwd('admin', 'admin')
box.once('kv_db', createDB)
log.info('db space got %d records', box.space.db:count())

-- create HTTP server ---------------------------------------------------------
-- common handle for /kv/id commands
idHandle = function(req)
    
    if req.method == 'PUT' then
        return putHandle(req)
    end
    
    if req.method == 'GET' then
        return getHandle(req)
    end
    
    if req.method == 'DELETE' then
        return deleteHandle(req)
    end

    local record_json = 'Unknown REST command, please use POST /kv, PUT /kv/key, GET /kv/key or /kv, DELETE /kv/key'
    req:render({json = record_json})
    req.status = 400
    log.error('Unknown REST command (with key - /kv/key): %s', req.method)
    return req;
end

-- common handle for /kv commands
noidHandle = function(req)

    if req.method == 'GET' then
        return getAllHandle(req)
    end
    
    if req.method == 'POST' then
        return postHandle(req)
    end

    local record_json = 'Unknown REST command, please use POST /kv, PUT /kv/key, GET /kv/key or /kv, DELETE /kv/key'
    req:render({json = record_json})
    req.status = 400
    log.error('Unknown REST command (without key - /kv): %s', req.method)
    return req;
end

-- handle for POST command
postHandle = function(req)
    local req_json = req:json()
    if not req_json.body or not req_json.body.key or not req_json.body.value then
        local record_json = 'Body is invalid';
        req:render({json = record_json})
        req.status = 400
        log.error('POST command with invalid body')
        return req;
    end
    local key = req_json.body.key
    local existing_record = box.space.db:select{key}[1]
    if existing_record then
        local record_json = 'Key: ' .. key .. ' already exists';
        req:render({json = record_json})
        req.status = 409
        log.error('POST command with already existing key: %s', key)
        return req;
    end
    local new_record = box.space.db:insert{ key, req_json.body.value }
    log.warn('POST command added record with key: %s', key);
    return req:render({json = new_record})
end

-- handle for PUT command
putHandle = function(req)
    local req_json = req:json()
    if not req_json.body or not req_json.body.value then
        local record_json = 'Body is invalid';
        req:render({json = record_json})
        req.status = 400
        log.error('PUT command with invalid body')
        return req;
    end
    local key = req:stash('id')
    local existing_record = box.space.db:select{key}[1]
    if not existing_record then
        local record_json = 'Key: ' .. key .. ' does not exists';
        req:render({json = record_json})
        req.status = 404
        log.error('PUT command with unknown key: %s', key)
        return req;
    end
    local record = box.space.db:put{ key, req_json.body.value }
    log.warn('PUT command changed record with key: %s', key);
    return req:render({json = record})
end

-- handle for GET command
getHandle = function(req)
    local key = req:stash('id')
    local existing_record = box.space.db:select{key}[1]
    if not existing_record then
        local record_json = 'Key: ' .. key .. ' does not exists';
        req:render({json = record_json})
        req.status = 404
        log.error('GET command with unknown key: %s', key)
        return req;
    end
    log.warn('GET command returned record with key: %s', key);
    return req:render({json = existing_record})
end

-- handle for GET all command
getAllHandle = function(req)
    local record = box.space.db.index.primary:select()
    log.warn('GET command returned all records');
    return req:render({json = record})
end

-- handle for DELETE command
deleteHandle = function(req)
    local key = req:stash('id')
    local existing_record = box.space.db:select{key}[1]
    if not existing_record then
        local record_json = 'Key: ' .. key .. ' does not exists';
        req:render({json = record_json})
        req.status = 404
        log.error('DELETE command with unknown key: %s', key)
        return req;
    end    
    local deleted_record = box.space.db:delete{key}
    log.warn('DELETE command removed record with key: %s', key)
    return req:render({json = deleted_record})
end

http_service = require('http.server').new(nil, 8080, { app_dir = '/opt/tarantool/' })
http_service:route({ path = '/kv/:id'}, idHandle)
http_service:route({ path = '/kv'}, noidHandle)
http_service:start()