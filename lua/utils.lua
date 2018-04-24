local json = require "cjson"

local ngx_req = ngx.req
local ngx_log = ngx.log
local ngx_var = ngx.var
local str_sub = string.sub
local str_lower = string.lower
local str_format = string.format

local _M = {}
local mt = {__index = _M}

local ERROR_RESP = {
    ["code"] =  "4000",
    ["msg"] = "服务器异常",
    ["data"] =  "",
}

local UNLOGIN_API = {
    ["current_detail"] = "活期详情",
    ["current_get_interest"] = "活期预期收益",
    ["project_detail"] = "定期详情",
    ["project_get_interest"] = "定期预期收益",
    ["project_invest_records"] = "定期投资记录",
    ["project_refund_record"] = "定期回款计划",
    ["credit_assign_project_detail"] = "债权转让项目详情",
    ["login"] = "用户登录",
    ["check_login"] = "用户登录",
    ["check_phone"] = "用户检测",
    ["logout"] = "用户登出",
    ["register_agreement"] = "注册协议",
    ["check_register_code"] = "检测注册验证码",
    ["register"] = "注册手机号 - 设置密码",
    ["home"] = "App4.0首页接口数据",
    ["home_pop"] = "首页弹窗",
    ["current_index"] = "零钱计划",
    ["project_index"] = "定期理财列表",
    ["project_preview"] = "定期理财列表",
    ["assign_project"] = "App4.0首页接口数据",
    ["current_index"] = "理财列表",
    ["send_sms"] = "发送手机验证码",
    ["check_code"] = "验证验证码并判断是否实名",
    ["check_real_name"] = "验证实名信息(名字+身份证号)",
    ["find_password"] = "找回登录密码",
    ["more"] = "更多接口",
    ["feedback"] = "意见反馈",
    ["ad_show"] = "广告",
    ["ads_show"] = "广告",
    ["app_activate"] = "app激活记录设备id",
}

local OLD_DOMAIN = "9douyu"
local METHOD_POST = "POST"

local URI_TEMPLATE = {
    ["proxy_cg_uri"] = "https://bank-%s.test.com/%s",
    ["proxy_origin_uri"] = "https://%s.test.com/%s",
    ["upload_cg_uri"] = "bank-%s.test.com",
    ["upload_origin_uri"] = "%s.test.com",
}

-- 错误信息格式化返回
function _M.call_error(self, msg)
    ERROR_RESP["msg"] = msg
    ngx.say(json.encode(ERROR_RESP))
    ngx.exit(ngx.HTTP_OK)
end

-- 从请求参数列表中获取token
function _M.get_token(self, request_args)
    local token_data = request_args["token"]
    local token = ""
    if token_data then
        if type(token_data) == "table" and #token_data > 1 then
            token = token_data[1]
        else
            token = token_data
        end
    end
    return token
end

-- 获取请求的api
function _M.get_api(self)
    local api = str_sub(ngx_var.uri, 2)
     if api == "" or not api then
        ngx_log(ngx.ERR, "api not found: ", api)
        self.call_error("请求地址不存在")
     end
     return api
end

-- 获取接口描述
function _M.get_api_desc(self, api)
    return UNLOGIN_API[api]
end

-- 获取客户所有的请求参数列表
function _M.get_request_info(self)
    local method = ngx_req.get_method()
    local request_args = {}
    if method == METHOD_POST then
        ngx_req.read_body()
        request_args = ngx_req.get_post_args()
    else
        request_args = ngx_req.get_uri_args()
    end
    return request_args, method
end

function _M.get_request_headers(self)
    local headers = ngx_req.get_headers()
    return headers
end

local function format_uri(client, domain, api, is_upload)
    client = str_lower(client)
    domain = str_lower(domain)
    local url = ""
    if domain == OLD_DOMAIN then
        if is_upload then
            url = str_format(URI_TEMPLATE["upload_origin_uri"], client)
        else
            url = str_format(URI_TEMPLATE["proxy_origin_uri"], client, api)
        end
    else
        if is_upload then
            url = str_format(URI_TEMPLATE["upload_cg_uri"], client)
        else
            url = str_format(URI_TEMPLATE["proxy_cg_uri"], client, api)
        end
    end

    return url
end

function _M.format_upload_uri(self, client, domain, api)
    local url = format_uri(client, domain, api, true)
    ngx_log(ngx.NOTICE, "upload_url: ", url)
    return url
end

function _M.format_proxy_uri(self, client, domain, api)
    local url = format_uri(client, domain, api, false)
    ngx_log(ngx.NOTICE, "proxy_url: ", url)
    return url
end


function _M.new(self)
    return setmetatable({}, mt)
end

return _M



