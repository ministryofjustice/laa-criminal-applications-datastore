apiVersion: batch/v1
kind: CronJob
metadata:
  name: monitor-deletion-log-cron-job-staging
  namespace: laa-criminal-applications-datastore-staging
spec:
  schedule: "0 1 * * *" # daily at 1am (after midnight deletion job)
  timeZone: "Europe/London"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            tier: worker
        spec:
          serviceAccountName: laa-criminal-applications-datastore-staging-service
          restartPolicy: OnFailure
          containers:
          - name: monitor-deletion-log-job
            image: ${ECR_URL}:${IMAGE_TAG}
            imagePullPolicy: Always
            command:
              - bin/rails
              - monitor_deletion_log
            resources:
              limits:
                cpu: 50m
                memory: 256Mi
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

