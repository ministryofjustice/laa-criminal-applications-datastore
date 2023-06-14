# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :token, :_key, :crypt, :salt,

  # Attributes relating to an application
  # It does partial matching (i.e. `case_details` is covered by `details`)
  :application,
  :details,
  :first_name,
  :last_name,
  :reason,
  :searchable_text,
]
