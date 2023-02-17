// Description pipeline
pipeline {
  agent any
  stages {
    stage('Submit Stack') { 
      steps {
          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'AutoCredName', usernameVariable: 'AutoCredUser', passwordVariable: 'AutoCredPass']]) {
              sh script:'''
              #!/bin/bash
              chmod 755 code/03-one-webserver
              cd ./code/03-one-webserver
              echo "INITILISING TERRAFORM MODULE"
              terraform init
              echo "GENERATING TERRAFORM PLAN"              
              terraform plan -out=training-infra-plan
              echo "GENERATING TERRAFORM RESOURCES IN THE SUBSCRIPTION"
              terraform apply
              '''
            }//end withCredentials
            sh "exit 0"
         }//end catcherror
      }
    }
 /*   stage('Update Inventory'){
      steps{
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              withCredentials([sshUserPrivateKey(credentialsId: 'a59a13e3-8e2f-4920-83c9-a49b576e5d58', keyFileVariable: 'myTestKeyPair02')]) {
                sh 'ansible-playbook ./ansible/playbooks/update_inventory.yml --user ubuntu --key-file ${myTestKeyPair02}' 
           }//end withCredentials
          sh "exit 0"
         }//end catchError
      }
    }
    stage('Configure Tomcat') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          withCredentials([sshUserPrivateKey(credentialsId: 'a59a13e3-8e2f-4920-83c9-a49b576e5d58', keyFileVariable: 'myTestKeyPair02')]) {
            sh 'ansible-playbook ./ansible/playbooks/tomcat-setup.yml --user ubuntu -vvv --key-file ${myTestKeyPair02}'
            }//end withCredentials
          sh "exit 0"
         }//end catchError
      }//end steps
    } //end stage */
  } //end stages
}//end pipeline