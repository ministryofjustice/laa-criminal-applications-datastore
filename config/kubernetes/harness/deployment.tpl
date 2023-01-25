apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-harness
  namespace: laa-criminal-applications-datastore-harness
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
      app: laa-criminal-applications-datastore-web-harness
  template:
    metadata:
      labels:
        app: laa-criminal-applications-datastore-web-harness
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
              name: configmap-harness
          - secretRef:
              name: secrets-harness
        env:
          # secrets created by terraform
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-instance
                key: url
