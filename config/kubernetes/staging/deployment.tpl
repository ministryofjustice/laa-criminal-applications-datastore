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
        resources:
          requests:
            cpu: 125m
            memory: 500Mi
          limits:
            cpu: 250m
            memory: 1Gi
        readinessProbe:
          httpGet:
            path: /ping
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
            path: /ping
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
          - name: AWS_REGION
            valueFrom:
              secretKeyRef:
                name: crime-applications-dynamodb-output
                key: aws_region
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: crime-applications-dynamodb-output
                key: access_key_id
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: crime-applications-dynamodb-output
                key: secret_access_key
          - name: APPLICATIONS_TABLE_NAME
            valueFrom:
              secretKeyRef:
                name: crime-applications-dynamodb-output
                key: table_name
          - name: APPLICATIONS_TABLE_ARN
            valueFrom:
              secretKeyRef:
                name: crime-applications-dynamodb-output
                key: table_arn
