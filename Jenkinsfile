pipeline {
  agent any

  environment {
    PYTHONPATH = '.'
    PATH_VENV = 'ci_venv/bin'
  }

  stages {

    stage('Checkout code') {
      steps {
        git 'https://github.com/flaviooria/CI_bootcamp_24_unir.git'
      }
    }

    stage('List directories') {
      steps {
        sh 'ls -la'
      }
    }

    stage('Create virtualenv') {
      steps {
        sh 'python -m venv ci_venv'

        sh '. $WORKSPACE/$PATH_VENV/activate'

        sh '$WORKSPACE/$PATH_VENV/pip install -r requirements.txt'
      }
    }

    stage('Workspace') {
      steps {
        sh 'echo $WORKSPACE'
      }
    }

    stage('Build') {
      steps {
        echo 'Build ...'
      }

    }

    stage('Tests') {
      parallel {
        stage('Run unit test') {
          steps {
            catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
              sh '$WORKSPACE/$PATH_VENV/pytest --junitxml=result-unit.xml test/unit'
            }
          }
        }

        stage('Run flask and wiremock') {
          steps {
            sh '$WORKSPACE/$PATH_VENV/python app/api.py &'
            sh 'java -jar wiremock-standalone-3.10.0.jar --port 8083 &                                                                                                 '
          }
        }

        stage('Run test rest') {
          steps {
            catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
              sh '$WORKSPACE/$PATH_VENV/pytest --junitxml=result-rest.xml test/rest'
            }
          }
        }
      }
    }

    stage('Show junit graph') {
      steps {
        junit 'result-*.xml'
      }
    }
  }
} 