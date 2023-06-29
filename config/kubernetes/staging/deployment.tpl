apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-staging
  namespace: laa-criminal-applications-datastore-staging
spec:
  replicas: 2
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: laa-criminal-applications-datastore-web-staging
  template:
    metadata:
      labels:
        app: laa-criminal-applications-datastore-web-staging
        tier: frontend
    spec:
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
          initialDelaySeconds: 15
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 30
          periodSeconds: 10
        envFrom:
          - configMapRef:
              name: configmap-staging
          - secretRef:
              name: secrets-staging
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
          - name: EVENTS_SNS_TOPIC_KEY_ID
            valueFrom:
              secretKeyRef:
                name: application-events-sns-topic
                key: access_key_id
          - name: EVENTS_SNS_TOPIC_SECRET
            valueFrom:
              secretKeyRef:
                name: application-events-sns-topic
                key: secret_access_key
