pipeline {
    agent {
        label "jenkins-nodejs"
    }
    environment {
      ORG               = 'yhidai'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('app-1 CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          APP_NAME = 'app-1'
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('./app-1') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
            }
          }

          dir ('./app-1/charts/preview') {
           container('nodejs') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
      stage('app-1 Build Release') {
        when {
          branch 'master'
        }
        environment {
          APP_NAME = 'app-1'
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('./app-1') {
            container('nodejs') {
              // ensure we're not on a detached head
              sh "git checkout master"
              sh "git config --global credential.helper store"
              sh "jx step git credentials"
              // so we can retrieve the version in later steps
              sh "echo \$(jx-release-version) > VERSION"
            }
          }
          dir ('./app-1/charts/app-1') {
            container('nodejs') {
              sh "make tag"
            }
          }
          dir ('./app-1') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
            }
          }
        }
      }
      stage('app-1 Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./app-1/charts/app-1') {
            container('nodejs') {
              sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'jx step helm release'

              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
      stage('app-2 CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          APP_NAME = 'app-2'
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('./app-2') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
            }
          }

          dir ('./app-2/charts/preview') {
           container('nodejs') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
      stage('app-2 Build Release') {
        environment {
          APP_NAME = 'app-2'
        }
        when {
          branch 'master'
        }
        steps {
          dir ('./app-2') {
            container('nodejs') {
              // ensure we're not on a detached head
              sh "git checkout master"
              sh "git config --global credential.helper store"
              sh "jx step git credentials"
              // so we can retrieve the version in later steps
              sh "echo \$(jx-release-version) > VERSION"
            }
          }
          dir ('./app-2/charts/app-2') {
            container('nodejs') {
              sh "make tag"
            }
          }
          dir ('./app-2') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
            }
          }
        }
      }
      stage('app-2 Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./app-2/charts/app-2') {
            container('nodejs') {
              sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'jx step helm release'

              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            sh 'sleep 100'
            cleanWs()
        }
    }
  }
