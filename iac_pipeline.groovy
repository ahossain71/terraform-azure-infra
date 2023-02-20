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
              echo "GENERATING TERRAFORM RESOURCES IN THE SUBSCRIPTION..."
              terraform apply -auto-approve
              #sleep 1m
              #echo "DESTROYING A VM RESOURCE IN THE RESOURCE GROUP"
              #terraform destroy -target=azurerm_linux_virtual_machine.tftraining -auto-approve
              '''
            }//end withCredentials
            sh "exit 0"
         }//end catcherror
      }
    }
  /*stage('Update Inventory'){
      steps{
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              withCredentials([sshUserPrivateKey(credentialsId: '45b077dc-baea-4366-8573-1289626eb6d3', keyFileVariable: 'my-trng-ssh-key')]) {
                sh 'ansible-playbook ./ansible/playbooks/update_inventory.yml --user ubuntu --key-file ${myTestKeyPair02}' 
           }//end withCredentials
          sh "exit 0"
         }//end catchError
      }
    }
  */
    stage('Configure Tomcat') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          withCredentials([sshUserPrivateKey(credentialsId: '1af83a22-d280-4642-a6bc-1e256e53a239', keyFileVariable: 'my-trng-devops-ssh-02')]) {  
            sh 'ansible-playbook ./ansible/playbooks/tomcat-setup.yml --user ubuntu -vvv --key-file ${my-trng-devops-ssh-02}'
            sh script:'''
             #!/bin/bash
              cd /var/lib/jenkins/workspace/training-iac
              chmod 755 ./ansible/playbooks
              ansible-playbook ./ansible/playbooks/tomcat-setup.yml --user ubuntu -vvv --key-file ${my-trng-devops-ssh-02}
            '''
            }//end withCredentials
          sh "exit 0"
         }//end catchError
      }//end steps
    } //end stage */
  } //end stages
}//end pipeline