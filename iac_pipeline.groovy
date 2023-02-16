// Description pipeline
pipeline {
  agent any
  stages {
    stage('Submit Stack') { 
      steps {
          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'AutoCredName', usernameVariable: 'AutoCredUser', passwordVariable: 'AutoCredPass']]) {
              sh "cd /training-iac/code/03-one-webserver"
              sh "terraform init"
              sh "terraform plan -out=training-infra-plan"
              sh "terraform apply"
              //sh "aws cloudformation deploy --template-file $workspace/code/05-cluster-webserver/main.tf --stack-name Training-infra-Stack-Test --location East US"
              //sh "echo SKIPPING INFRASTRUCTURE CREATION/UPDATE for now .."
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