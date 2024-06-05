// pipeline {
//     agent any

//     parameters {
//         choice(name: 'Country', choices: ['NA'], description: 'Select which country/region to deploy resources')
//         choice(name: 'ENV', choices: ['dev', 'test', 'stage'], description: 'Select which env to deploy in')
//     }
//     stages {

//         stage ('Copying tf_vars file outside') {
//             steps {
//                 sh "'cp /${ENV}_tfvars/${Country}/* .'"
//             }   
//         }

//         stage ('Initailising backend') {
//             steps {
//                 sh 'terraform init -backend-config=\"bucket=bkt-viq-st-na-infra-np-s-tf-state\" -backend-config=\"prefix=backend/viq-st-${COUNTRY}-$(echo $ENV | head -c 1)\"'
//             }
//         }

//         stage ('Infrastructure Plan') {
//             steps {
//                 sh "'terraform plan'"
//             }
//         }
//     }
// }

// pipeline {
//     agent any

//     parameters {
//         choice(name: 'Country', choices: ['NA','EU'], description: 'Select country/region to deploy in')
//         choice(name: 'ENV', choices: ['dev', 'test', 'stage'], description: 'Select env in which to deploy')
//     }
//     stages {

//         stage ('Copying tf_vars file outside') {
//             steps {
//                 sh "'cp ${ENV}_tfvars/${COUNTRY}/* .'"
//             }   
//         }

//         stage ('Initailising backend') {
//             steps {
//                 sh 'terraform init -backend-config="prefix=backend/viq-st-${COUNTRY}-$(echo $ENV | head -c 1)"'
//             }
//         }

//         stage ('Infrastructure apply') {
//             steps {
//                 sh "'terraform apply -auto-approve'"
//             }
//         }
//     }
// }