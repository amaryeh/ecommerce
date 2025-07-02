# ecommerce
sample production ready ecommerce platform on AWS
graph TD
  A[End Users (Browser/Mobile)] --> B[Amazon CloudFront (CDN + WAF)]
  B --> C[S3 Bucket (Static SPA)]
  C --> D[JS/API Calls via HTTPS]
  D --> E[Amazon API Gateway (REST API)]

  subgraph Auth
    G[Amazon Cognito<br>(User Pools + JWTs)]
  end
  E --> G
  G --> E

  E --> F[AWS Lambda Functions<br>(Product Logic, Auth, Orders)]
  F --> H[Amazon RDS<br>(PostgreSQL Multi-AZ)]

  subgraph Realtime Pipeline
    F --> I[Amazon EventBridge]
    I --> J[AWS Lambda (Processor)]
    J --> K[Kinesis Data Firehose]
    K --> L[S3 / Redshift (Analytics)]
  end
