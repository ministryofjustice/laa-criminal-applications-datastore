apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-production
  namespace: laa-criminal-applications-datastore-production
spec:
  replicas: 4
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: laa-criminal-applications-datastore-web-production
  template:
    metadata:
      labels:
        app: laa-criminal-applications-datastore-web-production
        tier: frontend
    spec:
      serviceAccountName: laa-criminal-applications-datastore-production-service
      containers:
      - name: webapp
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
          - containerPort: 3000
          - containerPort: 9394
        resources:
          requests:
            cpu: 25m
            memory: 1Gi
          limits:
            cpu: 500m
            memory: 3Gi
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /ping
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          failureThreshold: 1
          periodSeconds: 10
        startupProbe:
          httpGet:
            path: /ping
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
        envFrom:
          - configMapRef:
              name: configmap-production
          - secretRef:
              name: laa-criminal-applications-datastore-secrets
        env:
          # secrets created by terraform
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-instance
                key: url
          - name: API_AUTH_SECRET_APPLY
            valueFrom:
              secretKeyRef:
                name: api-auth-secrets
                key: crime_apply
          - name: API_AUTH_SECRET_REVIEW
            valueFrom:
              secretKeyRef:
                name: api-auth-secrets
                key: crime_review
          - name: API_AUTH_SECRET_MAAT_ADAPTER
            valueFrom:
              secretKeyRef:
                name: api-auth-secrets
                key: maat_adapter
          - name: EVENTS_SNS_TOPIC_ARN
            valueFrom:
              secretKeyRef:
                name: application-events-sns-topic
                key: topic_arn
          - name: S3_BUCKET_NAME
            valueFrom:
              secretKeyRef:
                name: s3-bucket
                key: bucket_name
