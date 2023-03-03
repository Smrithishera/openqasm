#!/usr/bin/bash

liveBranch=${1:-main}
destDir=${2:-"./publish_build"}

echo "Live branch is ${liveBranch}"
echo "Destination dir is ${destDir}"

# initialize the destination folder
mkdir -p ${destDir}/versions

# Build the stable version list
unset versionList
for branch in `git for-each-ref --format='%(refname:short)' --sort=-refname refs/remotes/origin/stable/`; do
  versionNum=${branch/*stable\//}

  if [ -z "${versionList}" ]
  then
    versionList="${versionNum}"
  else
    versionList="${versionList},${versionNum}"
  fi
done

# Now build each stable version and copy to destination folder
echo "VersionList is ${versionList}"
for branch in `git for-each-ref --format='%(refname:short)' --sort=-refname refs/remotes/origin/stable/`; do
  versionNum=${branch/*stable\//}
  
  echo "Checkout stable branch ${branch} with version number ${versionNum}"
  git checkout ${branch}

  # build
  VERSION=${versionNum} VERSION_LIST=${versionList} make html

  echo "Copy to publish dir ${destDir}/versions/${versionNum}"
  cp -r build/html ${destDir}/versions/${versionNum}
done

echo "Getting live branch ${liveBranch}"
git checkout origin/${liveBranch}

# build
VERSION_LIST=${versionList} make html

echo "Copy to publish dir"
cp -r build/html/* ${destDir}
