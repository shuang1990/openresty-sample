local mysql = require "resty.mysql"
local utils = require "utils"

local ngx_log = ngx.log
local str_format = string.format
local ngx_re_match = ngx.re.match
local str_lower = string.lower
local utils_obj = utils:new()

local DEFAULT_CLIENT = {
    ["ios"]     = "IOS",
    ["android"] = "安卓",
}

local DEFAULT_DOMAIN = {
    ["app"]     = "app",
    ["test"]    = "test",
}

local _M = {}
local mt = {__index = _M }

function _M.check_login_and_token(self, token, api, api_desc)
    local pattern = "[0-9a-zA-Z]{40}"
    --需要登录的接口
    if not api_desc then
        local m = ngx_re_match(token, pattern, "o")
        if token == "" or not m then
            ngx_log(ngx.ERR, "invalid token: ", token)
            utils_obj:call_error("token错误")
        end
    end
end

function _M.check_client(self, client)
    if not client or client == "" then
        ngx_log(ngx.ERR, "param client miss: ")
        utils_obj:call_error("client不能为空")
    end

    client = str_lower(client)
    if not DEFAULT_CLIENT[client] then
        ngx_log(ngx.ERR, "invalid client: ", client)
        utils_obj:call_error("client错误")
    end

end

function _M.check_domain(self, domain)
    if not domain or domain == "" then
        ngx_log(ngx.ERR, "param domain miss: ")
        utils_obj:call_error("domain不能为空")
    end

    domain = str_lower(domain)
    if not DEFAULT_DOMAIN[domain] then
        ngx_log(ngx.ERR, "invalid domain: ", domain)
        utils_obj:call_error("domain错误")
    end
end

function _M.check_token_expired(token)
    local db, err = mysql:new()
    if not db then
        ngx_log(ngx.ERR, "failed to instantiate mysql: ", err)
        utils_obj:call_error("服务器错误")
    end

    db:set_timeout(2000)

    local ok, err, errcode, sqlstate = db:connect{
        host = "localhost",
        port = 3306,
        database = "test",
        user = "root",
        password = "123456",
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }

    if not ok then
        ngx_log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        utils_obj:call_error("服务器错误")
    end

    local current_time = ngx.localtime()
    local sql = str_format("select * from module_oauth_access_tokens where access_token = '%s' and expires > '%s'",token, current_time)

    ngx_log(ngx.NOTICE, "SQL: ", sql)
    local res, err, errcode, sqlstate = db:query(sql, 1)

    if #res == 0 then
        ngx_log(ngx.ERR, "record is not found or token is expired: ", token)
        utils_obj:call_error("token已失效")
    else
        ngx_log(ngx.NOTICE, "result: ", json.encode(res))
    end

    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        ngx_log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end
end

function _M.new(self)
    return setmetatable({}, mt)
end

return _M




