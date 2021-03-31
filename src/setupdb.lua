local sql = require 'sqlite3'
local config = require './config'
local conn = sql.open 'invicta.db'

conn:exec([[
CREATE TABLE IF NOT EXISTS guild_settings (
	guild_id TEXT PRIMARY KEY,
	prefix TEXT DEFAULT ']] .. config.prefix .. [[',
	disabled_modules TEXT DEFAULT '{}',
	disabled_commands TEXT DEFAULT '{}',
	auto_role TEXT,
	mute_role TEXT,
	welcome_channel TEXT,
	log_channel TEXT
);
CREATE TABLE IF NOT EXISTS mutes (
	guild_id TEXT,
	user_id TEXT,
	length REAL,
	is_active BOOLEAN DEFAULT 1 NOT NULL CHECK (is_active IN (0,1)),
	end_timestamp REAL,
	PRIMARY KEY (guild_id, user_id),
	FOREIGN KEY (guild_id) REFERENCES guild_settings(guild_id)
);
]])