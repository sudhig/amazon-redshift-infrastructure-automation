
#CREATE/NA
metReqs=""
vpc_id=""
redshift_endpoint=""
dms_migration_to_redshift_target=""
sct_on_prem_to_redshift_target=""
jmeter=""
#VPC DETAILS
cidr=""
number_of_az=""
cidr_mask=""
existing_vpc_id=""
#REDSHIFT DETAILS
existing_RS_id=""
cluster_identifier=""
database_name=""
node_type=""
number_of_nodes=""
master_user_name=""
subnet_type=""
encryption=""
loadTPCdata=""
#DMS Details
migration_type=""
dms_instance_type=""
dms_subnet_type=""
source_db=""
source_engine=""
source_schema=""
source_host=""
source_user=""
source_port="1"
#SCT KeyName
sct_key_name=""
#JMeter KeyName
key_name=""
jmeter_node_type="c5.9xlarge"
## Colored input's
RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
BLUE="\033[36;5;11m"
coloredQuestion="$(echo -e [$BOLD$YELLOW"?? Input Required"$RESET])"
coloredLoading="$(echo -e $BOLD$BLUE"..."$RESET)"


##THIS IS WHERE THE MENU STARTS


while true; do
    read -r -p "$coloredQuestion Are the prerequisites met?(Y/N): " answer
    case $answer in
        [Yy]* ) break;;
        [Nn]* ) 
            echo "Please visit the link below"
            echo "https://github.com/aws-samples/amazon-redshift-infrastructure-automation#prerequisites"; 
            exit;;
        * ) echo "Please answer Y or N.";;
    esac
done
echo

#ANYTHING RELATED TO VPC DETAILS
configureVPCDetails (){
while true; do
    read -r -p "$coloredQuestion Do you wish to create a new VPC? (Y/N): " answer
    case $answer in
        [Yy]* ) export vpc_id="CREATE"; 
                 break;;
        [Nn]* ) export vpc_id="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done
echo

if [ "$vpc_id" = "CREATE" ]; 
then 
    echo "Please configure VPC details..."
    read -r -p "$coloredQuestion [VPC Details]: Please provide a VPC CIDR Range (format xxx.xxx.xxx.xxx/xx): " cidr
    echo
    read -r -p "$coloredQuestion [VPC Details]: How many Availability Zones: " number_of_az
    echo
    read -r -p "$coloredQuestion [VPC Details]: Please provide a CIDR MASK(number only, no /): " cidr_mask
    echo

elif [ "$vpc_id" = "N/A" ];
then
    
    echo "[$coloredLoading]Loading your VPC's..."
    echo
    ~/amazon-redshift-infrastructure-automation/scripts/shell_menu/bash-menu-cli-commands.sh
    readarray -t list < vpclist.txt
    PS3='[Input Required] Please select your VPC: '
    select selection in "${list[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            vpc_id=$selection
            break
        fi
    done
    echo
    echo "You have choosen $selection"
fi
}

##Call VPC Menu
configureVPCDetails
echo

#ANYTHING RELATED TO REDSHIFT DETAILS
configureRedshiftDetails (){
while true; do
    read -r -p "$coloredQuestion Do you wish to create a new Redshift? (Y/N): " answer
    case $answer in
        [Yy]* ) export redshift_endpoint="CREATE"; break;;
        [Nn]* ) export redshift_endpoint="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done
echo

if [ "$redshift_endpoint" = "CREATE" ]; 
then 
    echo "[Input Required][REDSHIFT Details]: Please configure Redshift details..."
    echo
    read -r -p "$coloredQuestion [REDSHIFT Details]: Please provide a cluster indentifier: " cluster_identifier
    echo
    read -r -p "$coloredQuestion [REDSHIFT Details]: Please provide a Redshift database name: " database_name
    echo
    read -r -p "$coloredQuestion [REDSHIFT Details]: Please provide a master user name: " master_user_name 
    echo

    PS3='[Input Required][REDSHIFT Details]: Please select your Redshift node type choice: '
    options=("dc2.large" "dc2.8xlarge" "ra3.xlplus" "ra3.4xlarge" "ra3.16xlarge" )
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            node_type=$selection
            break
        fi 
        echo
        echo "You have choosen $selection"  
    done
    echo
    read -r -p "$coloredQuestion [REDSHIFT Details]: How many nodes of $node_type? " number_of_nodes
    echo
    PS3='[Input Required][REDSHIFT Details]: Please select subnet type: '
    options=("PUBLIC" "PRIVATE" "ISOLATED")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            subnet_type=$selection
            break
        fi     
    done
    echo
    while true; do
    read -r -p "$coloredQuestion [REDSHIFT Details]: Would you like to use encryption? (Y/N) " answer
    case $answer in
        [Yy]* ) export encryption="Y"; break;;
        [Nn]* ) export encryption="N"; break;;
        * ) echo "Please answer Y or N.";;
    esac
    done
    echo
    while true; do
    read -r -p "$coloredQuestion [REDSHIFT Details]: Would you like to load TPC data? (Y/N) " loadTPCdata
    case $loadTPCdata in
        [Yy]* ) export loadTPCdata="Y"; break;;
        [Nn]* ) export loadTPCdata="N"; break;;
        * ) echo "Please answer Y or N.";;
    esac
    done        
    echo
    
elif [ "$redshift_endpoint" = "N/A" ];
then
    echo "[$coloredLoading]Loading your Redshift Clusters..."
    echo
     ~/amazon-redshift-infrastructure-automation/scripts/shell_menu/bash-menu-cli-commands.sh
            readarray -t list < redshiftlist.txt
            PS3='[Input Required] Please select your Redshift Cluster: '
            select selection in "${list[@]}"; do
                if [[ $REPLY == "0" ]]; then
                    echo 'Goodbye' >&2
                    exit
                else
                    redshift_endpoint=$selection
                    break
                fi
            done
            echo
            echo "You have choosen $selection"
fi
}
## CALL REDSHIFT MENU
configureRedshiftDetails
echo


##ANYTHING RELATED TO DMS DETAILS
configureSCTDMSDetails (){
while true; do
    read -r -p "$coloredQuestion Do you have an external database that you would like to migrate using DMS? (Y/N): " answer
    case $answer in
        [Yy]* ) export dms_migration_to_redshift_target="CREATE"; break;;
        [Nn]* ) export dms_migration_to_redshift_target="N/A"; break;;
        * ) echo "Please answer Y or N.";;   
    esac
done
echo

if [ "$dms_migration_to_redshift_target" = "CREATE" ]; 
then
    PS3='[Input Required][DMS Details]: Please select subnet type for DMS: '
    options=("PUBLIC" "PRIVATE" "ISOLATED" )
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            dms_subnet_type=$selection
            break
        fi     
    done
    PS3='[Input Required][DMS Details]: Please select your DMS Instance Size: '
    options=("dms.t3.medium" "dms.t3.large")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            dms_instance_type=$selection
            break
        fi     
    done
    echo
    PS3='[Input Required][DMS Details]: Please select your migration type: '
    options=( "full-load" "cdc" "full-load-and-cdc")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            migration_type=$selection
            break
        fi   
    done
    echo
    PS3='[Input Required][DMS DETAILS] What is the engine type: '
    options=( "mysql" "oracle" "postgres" "mariadb" "aurora" "aurora-postgresql" "opensearch" "redshift" "s3" "db2" "azuredb" "sybase" "dynamodb" "mongodb" "kinesis" "kafka" "elasticsearch" "docdb" "sqlserver" "neptune")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            source_engine=$selection
            break
        fi   
    done
    echo
    read -r -p "$coloredQuestion [DMS DETAILS] Please provide name of source database to migrate: " source_db
    echo
    read -r -p "$coloredQuestion [DMS DETAILS] What is the name of source schema: " source_schema
    echo
    read -r -p "$coloredQuestion [DMS DETAILS] What is the name of source host: " source_host
    echo
    read -r -p "$coloredQuestion [DMS DETAILS] What is the source user: " source_user
    echo
    read -r -p "$coloredQuestion [DMS DETAILS] What is the source port: " source_port
fi
echo

if [ "$dms_migration_to_redshift_target" = "CREATE" ]; 
then 
while true; do
    read -r -p "$coloredQuestion [SCT DETAILS] Do you need SCT? (Y/N)" answer
    case $answer in
        [Yy]* ) export sct_on_prem_to_redshift_target="CREATE"; break;;
        [Nn]* ) export sct_on_prem_to_redshift_target="N/A"; break;;
        * ) echo "Please answer Y or N.";;   
    esac
done
fi
echo

if [ "$sct_on_prem_to_redshift_target" = "CREATE" ]; 
then
    echo "[$coloredLoading]Loading your account keypairs..."
    echo
    ~/amazon-redshift-infrastructure-automation/scripts/shell_menu/bash-menu-cli-commands.sh
     readarray -t list < keypairlist.txt
        number=$(wc -l < keypairlist.txt) 
        if [ $number = "0" ]; 
        then 
            read -p "$coloredQuestion Your selected region has no account keypairs. Please create one in the AWS Management Console and enter the name here: " key_name
        else
            PS3='[Input Required] Please select the keypair for SCT: '
            select selection in "${list[@]}"; do
            key_name=$selection
            break
            done
        fi
        
        echo "You have choosen $selection"
fi
}

## CALL SCT MENU
configureSCTDMSDetails
echo

## ANYTHING RELATED TO JMETER
configureJMeterDetails (){
while true; do
    read -r -p "$coloredQuestion Would you like to use Jmeter? (Y/N): " answer
    case $answer in
        [Yy]* ) export jmeter="CREATE"; break;;
        [Nn]* ) export jmeter="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done
echo
if [ "$jmeter" = "CREATE" ]; 
then 
    PS3='[Input Required][REGION] Please select your ec2 nodetype for Jmeter: '
    options=("c5.9xlarge" "c5.12xlarge" "c5.18xlarge" "c5.24xlarge")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            jmeter_node_type=$selection
            break
        fi     
    done
    echo
    echo "[$coloredLoading]Loading your account keypairs..."
    echo
    ~/amazon-redshift-infrastructure-automation/scripts/shell_menu/bash-menu-cli-commands.sh
    readarray -t list < keypairlist.txt
    number=$(wc -l < keypairlist.txt)
        PS3='[Input Required] Please select the keypair for Jmeter: '
        if [ $number = "0" ]; 
        then 
            read -p "$coloredQuestion Your selected region has no account keypairs. Please create one in the AWS Management Console and enter the name here: " key_name
        else
            select selection in "${list[@]}"; do
            key_name=$selection
            break
            done
        fi
        echo "You have choosen $selection"
fi
}
## CALL JMETER MENU
configureJMeterDetails
echo
configureMiscDetails (){
PS3='[Input Required][REGION] Please select your region: '
    options=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
            echo "You have chosen $selection"
            current_region=$selection
            break
        fi     
    done
    echo
    read -p "$coloredQuestion Enter a stack name: " stack
    echo
    read -p "$coloredQuestion Enter your on prem CIDR range (format xxx.xxx.xxx.xxx/xx): " onprem_cidr
    echo
}

##CALL MISC DETAILS MENU
configureMiscDetails
while true; do
    PS3='If you wish to change any inputs. Please enter your choice: '
    options=("Reconfigure VPC Details" "Reconfigure Redshift Details" "Reconfigure DMS/SCT Details" "Reconfigure Jmeter Details" "Reconfigure Region/Stack Name/On-Prem CIDR" "Launch Resources")
    select opt in "${options[@]}"
    do
        case $opt in
            "Reconfigure VPC Details")
                configureVPCDetails;
                break
                ;;
            "Reconfigure Redshift Details")
                configureRedshiftDetails;
                break
                ;;
            "Reconfigure DMS/SCT Details")
                configureSCTDMSDetails;
                break
                ;;
            "Reconfigure Jmeter Details")
                configureJMeterDetails;
                break
                ;;
            "Reconfigure Region/Stack Name/On-Prem CIDR")
                configureMiscDetails;
                break
                ;;
            "Launch Resources")
                break 2
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
done

## TAKE SAVED VARIABLES AND BUILD USER_CONFIG.JSON FILE
JSON_STRING=$( jq -n \
                  --arg bn "$vpc_id" \
                  --arg on "$redshift_endpoint" \
                  --arg tl "$dms_migration_to_redshift_target" \
                  --arg sct "$sct_on_prem_to_redshift_target" \
                  --arg on "$redshift_endpoint" \
                  --arg ll "$cidr" \
                  --arg la "$number_of_az" \
                  --arg lt "$cidr_mask" \
                  --arg ci "$cluster_identifier" \
                  --arg db "$database_name" \
                  --arg nt "$node_type" \
                  --arg nn "$number_of_nodes" \
                  --arg mu "$master_user_name" \
                  --arg st "$subnet_type" \
                  --arg en "$encryption" \
                  --arg ltd "$loadTPCdata" \
                  --arg dmsST "$dms_subnet_type" \
                  --arg dmsIns "$dms_instance_type" \
                  --arg mt "$migration_type" \
                  --arg sdb "$source_db" \
                  --arg se "$source_engine" \
                  --arg ss "$source_schema" \
                  --arg sh "$source_host" \
                  --arg su "$source_user" \
                  --argjson sp "$source_port" \
                  --arg jnt "$jmeter_node_type" \
                  --arg jkn "$key_name" \
                  --arg jm "$jmeter" \
                  '{
                    vpc_id: $bn, 
                    redshift_endpoint: $on,
                    dms_migration_to_redshift_target: $tl,
                    sct_on_prem_to_redshift_target: $sct,  
                    jmeter: $jm,
                    vpc:{
                        vpc_cidr: $ll,
                        number_of_az: $la, 
                        cidr_mask: $lt
                    },
                    redshift:{
                        cluster_identifier: $ci,
                        database_name: $db,
                        node_type: $nt,
                        number_of_nodes: $nn,
                        master_user_name: $mu,
                        subnet_type: $st,
                        encryption: $en,
                        loadTPCdata: $ltd
                    },
                    dms_migration:{
                        dms_instance_type: $dmsIns,
                        subnet_type: $dmsST,
                        migration_type: $mt
                    },
                    external_database:{
                        source_db: $sdb,
                        source_engine: $se,
                        source_schema: $ss,
                        source_host: $sh,
                        source_user: $su,
                        source_port: $sp
                    },
                    other:{
                        key_name: $jkn,
                        jmeter_node_type: $jnt
                    }
                    }' \ >user-config.json ) 






