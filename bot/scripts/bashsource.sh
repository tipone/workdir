#!/bin/bash
# Workdir Buildbot Devops Example -- 2016 -- kansukse@gmail.com
# /bin/sh nin çalıştırabileceği türden rc file oluşturur

echo -e "#!/bin/bash\n# sh Globals" |tee ~/bashsource
cat ~/.bashrc |grep -v "#"|grep -v "^$"|grep -i "export\|source">> ~/bashsource
