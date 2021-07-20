helm package chisel
mv *.tgz ../charts/
helm repo index --merge ../charts/index.yaml  ../charts/ --url https://storage.googleapis.com/captains-charts/
# TODO: Copy dir to cloud