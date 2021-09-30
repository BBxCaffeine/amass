-- Copyright 2021 Jeff Foley. All rights reserved.
-- Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.

local json = require("json")

name = "CommonCrawl"
type = "api"

local urls = {}

function start()
    set_rate_limit(2)
end

function vertical(ctx, domain)
    urls = index_urls(ctx)
    if (urls == nil or #urls == 0) then
        return
    end

    for _, url in pairs(urls) do
        scrape(ctx, {['url']=build_url(url, domain)})
    end
end

function build_url(url, domain)
    return url .. "?url=*." .. domain .. "&output=json&fl=url"
end

function index_urls(ctx)
    local resp, err = request(ctx, {['url']="https://index.commoncrawl.org/collinfo.json"})
    if (err ~= nil and err ~= "") then
        log(ctx, "index URLs request to service failed: " .. err)
        return nil
    end

    local data = json.decode(resp)
    if (data == nil or #data == 0) then
        return nil
    end

    local urls = {}
    for _, u in pairs(data) do
        local url = u["cdx-api"]
        if (url ~= nil and url ~= "") then
            table.insert(urls, url)
        end
    end

    return urls
end
