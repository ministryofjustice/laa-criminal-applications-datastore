select
  crime_applications.id as application_id,
  crime_applications.status as status,
  crime_applications.offence_class as offence_class,
  crime_applications.reference as reference,
  crime_applications.review_status as review_status,
  redacted_submitted_applications.submitted_application as submitted_application
from crime_applications
  join redacted_submitted_applications on crime_applications.id = redacted_submitted_applicationsn.crime_application_id
