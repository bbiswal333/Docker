set -x

if [ -d mo-a9901609a ]; then exit 1; fi

mkdir mo-a9901609a
if ! mount -t cifs //mo-a9901609a.mo.sap.corp/XSA mo-a9901609a -o domain=global,user=service.infra.frmwk,password=$(cat password); then exit 1; fi

rm -rf upload

mkdir -p upload/51050846/DATA_UNITS

cp mo-a9901609a/51050846/* upload/51050846/
cp mo-a9901609a/51050846/DATA_UNITS/* upload/51050846/DATA_UNITS/

cp -r mo-a9901609a/51050846/DATA_UNITS/HDB_LCM_LINUX_X86_64     upload/51050846/DATA_UNITS/
cp -r mo-a9901609a/51050846/DATA_UNITS/HDB_SERVER_LINUX_X86_64  upload/51050846/DATA_UNITS/
cp -r mo-a9901609a/51050846/DATA_UNITS/XSA_RT_10_LINUX_X86_64   upload/51050846/DATA_UNITS/
cp -r mo-a9901609a/51050846/DATA_UNITS/XSA_CONTENT_10           upload/51050846/DATA_UNITS/

if ! umount mo-a9901609a; then exit 1; fi
rm -r mo-a9901609a
