def get_application_setting(arg_name, env_key, default_value)
  arg_index = ARGV.index(arg_name)
  arg = ARGV[arg_index + 1] if arg_index
  arg || ENV[env_key] || default_value
end