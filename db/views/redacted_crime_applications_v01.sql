select
  crime_applications.id as application_id,
  crime_applications.status as status,
  crime_applications.offence_class as offence_class,
  crime_applications.reference as reference,
  crime_applications.review_status as review_status
from crime_applications
