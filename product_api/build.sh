rm -rf build
mkdir build
pip install -r requirements.txt -t build/
cp -r app build/app
cd build
zip -r ../product-api.zip .
cd ..
export HASH=$(openssl dgst -sha256 -binary product-api.zip | base64)
aws s3 cp product-api.zip s3://ecommerce-artifacts-0ab1e846/lambdas/product-api.zip

