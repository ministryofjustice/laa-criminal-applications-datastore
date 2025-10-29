apiVersion: batch/v1
kind: CronJob
metadata:
  name: automate-deletion-cron-job-staging
  namespace: laa-criminal-applications-datastore-staging
spec:
  schedule: "0 0 * * *" # daily at midnight
  timeZone: "Europe/London"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            tier: worker
        spec:
          restartPolicy: OnFailure
          containers:
          - name: automate-deletion-job
            image: ${ECR_URL}:${IMAGE_TAG}
            imagePullPolicy: Always
            command:
              - bin/rails
              - automate_deletion
            resources:
              limits:
                cpu: 50m
                memory: 1Gi
            envFrom:
              - configMapRef:
                  name: configmap-staging
              - secretRef:
                  name: laa-criminal-applications-datastore-secrets
            env:
              - name: DATABASE_URL
                valueFrom:
                  secretKeyRef:
                    name: rds-instance
                    key: url
              - name: S3_BUCKET_NAME
                valueFrom:
                  secretKeyRef:
                    name: s3-bucket
                    key: bucket_name
