#!/usr/bin/lua
local tmppath = "/tmp/luplayer" --目录缓存位置
local musicpath = "/mnt/" --音乐文件夹位置
local get=os.getenv("QUERY_STRING")
local t={}
local get_file=""
local vol = 50 --默认音量

function decodeURI(s)
	s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end

function encodeURI(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end


--扫描文件
os.execute("ls "..musicpath.." > "..tmppath.." &")
local dir = io.open(tmppath, "r")
local data = dir:read("*a")
dir:close()
local findfile={}
local i=0
for v in string.gmatch(data, "([^%c]+)") do
	i=i+1
	findfile[i]=v
end

for k,v in string.gmatch(decodeURI(get),"(%w+)=([^%&]+)") do
	t[k]=v
end
for k,v in pairs(t) do
	if k=="ctrl" then
		if v=="pause" then
			os.execute ("killall -STOP madplay")

		elseif v=="play" then
			os.execute ("killall -CONT madplay")

		elseif v=="stop" then
			os.execute ("killall -9 madplay")

		elseif v=="playall" then
			os.execute ("killall -9 madplay")
			os.execute ("madplay -a -45 "..musicpath.."* &")

		end
		io.write("Status: 302 Moved Temporarily\n")
		io.write("Location: http://",os.getenv("HTTP_HOST"),os.getenv("SCRIPT_NAME"),"\n\n")
		os.exit(0)
	end
	if k=="l" then
		os.execute("killall -9 madplay")
		os.execute("madplay -a -30 "..musicpath..string.gsub(v, "+", "\\ ").." &")
		io.write("Status: 302 Moved Temporarily\n")
		io.write("Location: http://",os.getenv("HTTP_HOST"),os.getenv("SCRIPT_NAME"),"\n\n")
		os.exit(0)
	end

end

io.write("Status: HTTP/1.1 200 OK\n")
io.write("Content-Type: text/html\n\n")
io.write([[
	<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<title>LuPlayer</title>
		</head>
		<body>
			<h2>LuPlayer</h2>
			<a href="]],os.getenv("SCRIPT_NAME"),[[?ctrl=pause" target="_self">===暂停===</a><br />
			<a href="]],os.getenv("SCRIPT_NAME"),[[?ctrl=play" target="_self">===继续===</a><br />
			<a href="]],os.getenv("SCRIPT_NAME"),[[?ctrl=playall" target="_self">===全部播放===</a><br />
			<a href="]],os.getenv("SCRIPT_NAME"),[[?ctrl=stop" target="_self">===停止===</a><br />]])
	for k,v in pairs(findfile) do 
		io.write("\n<a href=\""..os.getenv("SCRIPT_NAME").."?l="..encodeURI(v).."&mode=a\" target=\"_self\">"..v.."</a><br />")
	end
io.write([[
		</body>
	</html>]])
