local sql = require 'sqlite3'
local config = require './config'
local conn = sql.open 'invicta.db'

conn:exec([[
CREATE TABLE IF NOT EXISTS guild_settings (
	guild_id TEXT PRIMARY KEY,
	prefix TEXT DEFAULT ']] .. config.prefix .. [[',
	disabled_modules TEXT DEFAULT '{}',
	disabled_commands TEXT DEFAULT '{}',
	custom_commands TEXT DEFAULT '{}',
	auto_role TEXT,
	welcome_channel TEXT,
	log_channel TEXT
);]])