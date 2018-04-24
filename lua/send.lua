local utils = require "utils"
local http = require "resty.http"

local pairs = pairs
local tbl_concat = table.concat
local str_sub = string.sub
local ngx_log = ngx.log
local ngx = ngx
local utils_obj = utils:new()

local _M = {}
local mt = {__index = _M}

function _M.send_request(self, request_args, proxy_url, method, accept)
    local params = ""
    for key, val in pairs(request_args) do
        local value = ""
        if type(val) ~= "table" then
            value = val
        elseif type(val) == "table" and #val > 1 then
            value = val[1]
        end
        local tmp = tbl_concat({key, "=", value})
        params = tbl_concat({params, "&", tmp})
    end

    params = str_sub(params, 2)
    ngx_log(ngx.NOTICE, params)

    local httpc = http:new()

    local res, err = httpc:request_uri(proxy_url, {
        method = method,
        body = params,
        headers = {
            ["Accept"] = accept,
            ["Content-Type"] =  "application/x-www-form-urlencoded",
        },
        ssl_verify = false
    })

    if not res then
        ngx_log(ngx.ERR, "Internal Server Error: ", err)
        utils_obj:call_error("服务器错误")
    else
        --请求404了
        if res.status == ngx.HTTP_NOT_FOUND then
            ngx_log(ngx.ERR, "url not found: ", url)
            utils_obj:call_error("页面不存在")
        elseif res.status ~= ngx.HTTP_OK then
            utils_obj:call_error("服务器错误")
        end
        ngx_log(ngx.NOTICE, res.body)
        ngx.say(res.body)
    end

    local ok, err = httpc:set_keepalive(10000, 10)
    if not ok then
        ngx_log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end
end


function _M.new()
    return setmetatable({}, mt)
end

return _M



