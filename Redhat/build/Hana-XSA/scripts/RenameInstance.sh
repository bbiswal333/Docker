set -x

PASSWORD='Toor1234'
number='97'
OLDHOST='mo-5f802811c.mo.sap.corp'
NEWHOST=$(hostname -f)

/usr/sap/hana/shared/SHN/hdblcm/hdblcm -b --action=rename_system --target_password=$PASSWORD --hostmap=$OLDHOST=$NEWHOST
