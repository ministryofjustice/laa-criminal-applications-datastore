class YearMonthFormat < Grape::Validations::Validators::Base
  FORMAT = '%Y-%B'.freeze

  def validate_param!(attr_name, params)
    Date.strptime(params[attr_name], FORMAT)
  rescue ArgumentError
    raise Grape::Exceptions::Validation.new(
      params: [@scope.full_name(attr_name)],
      message: "must be in '%Y-%B' format (e.g. '2025-November')"
    )
  end
end
