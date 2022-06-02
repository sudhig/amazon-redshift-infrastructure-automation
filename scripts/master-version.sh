
#CREATE/NA
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
source_db=""
source_engine=""
source_schema=""
source_host=""
source_user=""
source_port=""
#SCT KeyName
key_name=""
#JMeter KeyName
jmeter_key_name=""
jmeter_node_type="c5.9xlarge"

while true; do
    read -r -p "[Input Required] Are the prerequisites met? ---> https://github.com/aws-samples/amazon-redshift-infrastructure-automation#prerequisites (Y/N): " answer
    case $answer in
        [Yy]* ) break;;
        [Nn]* ) 
            echo "Please visit the link below"
            echo "https://github.com/aws-samples/amazon-redshift-infrastructure-automation#prerequisites"; exit;;
        * ) echo "Please answer Y or N.";;
    esac
done

#VPC
while true; do
    read -r -p "[Input Required] Do you wish to create a new VPC (Y/N): " answer
    case $answer in
        [Yy]* ) export vpc_id="CREATE"; 
                 break;;
        [Nn]* ) export vpc_id="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done
if [ "$vpc_id" = "CREATE" ]; 
then 
    read -r -p "[Input Required]: Please configure VPC details [Press ENTER to continue....]"
    read -r -p "[Input Required][VPC Details]: Please provide a VPC CIDR Range: " cidr
    read -r -p "[Input Required][VPC Details]: How many Availability Zones? " number_of_az
    read -r -p "[Input Required][VPC Details]: Please provide a CIDR MASK: " cidr_mask

elif [ "$vpc_id" = "N/A" ];
then
    read -r -p "[Input Required]: Please select from existing VPC's [Press ENTER to continue....]"
    echo "Loading your VPC's..."
    /bin/bash ./bash-menu-cli-commands.sh
    readarray -t list < vpclist.txt
    PS3='Please enter your choice or 0 to exit: '
    select selection in "${list[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
        
            vpc_id=$selection
            break
        fi
    done
    echo "You have choosen $selection"
fi

#REDSHIFT 
while true; do
    read -r -p "[Input Required] Do you wish to create a new Redshift? (Y/N): " answer
    case $answer in
        [Yy]* ) export redshift_endpoint="CREATE"; break;;
        [Nn]* ) export redshift_endpoint="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done

if [ "$redshift_endpoint" = "CREATE" ]; 
then 
    read -r -p "[Input Required][REDSHIFT Details]: Please configure Redshift details [Press ENTER to continue....]"
    read -r -p "[Input Required][REDSHIFT Details]: Please provide a cluster indentifier: " cluster_identifier
    read -r -p "[Input Required][REDSHIFT Details]: Please provide a Redshift database name: " database_name
    read -r -p "[Input Required][REDSHIFT Details]: Please provide a master user name: " master_user_name 

    PS3='[Input Required][REDSHIFT Details]: Please select your Redshift node type choice: '
    node_type=""
    options=("ds2.xlarge" "ds2.8xlarge" "dc1.large" "dc1.8xlarge" "dc2.large" "dc2.8xlarge" "ra3.xlplus" "ra3.4xlarge" "ra3.16xlarge" )
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
        echo $REPLY $selection
            node_type=$selection
            break
        fi   
    done

    read -r -p "[Input Required][REDSHIFT Details]: How many nodes of $node_type? " number_of_nodes
    
    PS3='[Input Required][REDSHIFT Details]: Please select subnet type: '
    options=("Public" "Private" )
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
        echo $REPLY $selection
            subnet_type=$selection
            break
        fi     
    done
    
    while true; do
    read -r -p "[Input Required][REDSHIFT Details]: Would you like to use encryption? (Y/N) " answer
    case $answer in
        [Yy]* ) export encryption="Y"; break;;
        [Nn]* ) export encryption="N"; break;;
        * ) echo "Please answer Y or N.";;
    esac
    done
    while true; do
    read -r -p "[Input Required][REDSHIFT Details]: Would you like to load TPC data? (Y/N) " loadTPCdata
    case $answer in
        [Yy]* ) export loadTPCdata="Y"; break;;
        [Nn]* ) export loadTPCdata="N"; break;;
        * ) echo "Please answer Y or N.";;
    esac
    done        
   
    
elif [ "$redshift_endpoint" = "N/A" ];
then
    while true; do
    read -r -p "[Input Required]: Would you like to provide an existing Redshift Cluster? " answer
    case $answer in
        [Yy]* ) 
        echo "Loading your Redshift Clusters..."
            /bin/bash ./bash-menu-cli-commands.sh
            readarray -t list < redshiftlist.txt
            PS3='Please enter your choice or 0 to exit: '
            select selection in "${list[@]}"; do
                if [[ $REPLY == "0" ]]; then
                    echo 'Goodbye' >&2
                    exit
                else
                    redshift_endpoint=$selection
                    break
                fi
            done
            echo "You have choosen $selection"
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer Y or N.";;
    esac
    done  
fi

#####DMS
while true; do
    read -r -p "[Input Required] Do you have an external database that you would like to migrate using DMS? (Y/N): " answer
    case $answer in
        [Yy]* ) export dms_migration_to_redshift_target="CREATE"; break;;
        [Nn]* ) export dms_migration_to_redshift_target="N/A"; break;;
        * ) echo "Please answer Y or N.";;   
    esac
done
if [ "$dms_migration_to_redshift_target" = "CREATE" ]; 
then
    PS3='[Input Required][DMS Details]: Please select your migration type: '
    options=( "full-load" "cdc" "full-load-and-cdc")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
        echo $REPLY $selection
            migration_type=$selection
            break
        fi   
    done
    read -r -p "[Input Required][DMS DETAILS] Please provide name of source database to migrate: " source_db
    PS3='[Input Required][DMS DETAILS] What is the engine type? '
    options=( "Oracle" "PostgreSQL" "Teradata" "Snowflake")
    select selection in "${options[@]}"; do
        if [[ $REPLY == "0" ]]; then
            echo 'Goodbye' >&2
            exit
        else
        echo $REPLY $selection
            source_engine=$selection
            break
        fi   
    done
    read -r -p "[Input Required][DMS DETAILS] What is the name of source schema? " source_host
    read -r -p "[Input Required][DMS DETAILS] What is the source user? " source_user
    read -r -p "[Input Required][DMS DETAILS] What is the source port? " source_port
fi

if [ "$dms_migration_to_redshift_target" = "CREATE" ]; 
then 
while true; do
    read -r -p "[Input Required] Do you need SCT? (Y/N)" answer
    case $answer in
        [Yy]* ) export sct_on_prem_to_redshift_target="CREATE"; break;;
        [Nn]* ) export sct_on_prem_to_redshift_target="N/A"; break;;
        * ) echo "Please answer Y or N.";;   
    esac
done
fi
if [ "$sct_on_prem_to_redshift_target" = "CREATE" ]; 
then 
    read -r -p "[Input Required] Please provide Key Name: " key_name

fi

while true; do
    read -r -p "[Input Required] Would you like to use Jmeter? (Y/N): " answer
    case $answer in
        [Yy]* ) export jmeter="CREATE"; break;;
        [Nn]* ) export jmeter="N/A"; break;;
        * ) echo "Please answer Y or N.";;
    esac
done
if [ "$jmeter" = "CREATE" ]; 
then 
    read -r -p "[Input Required] Please provide Key Name for Jmeter: " jmeter_key_name
fi
JSON_STRING=$( jq -n \
                  --arg bn "$vpc_id" \
                  --arg on "$redshift_endpoint" \
                  --arg tl "$dms_migration_to_redshift_target" \
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
                  --arg dmsST "$subnet_type" \
                  --arg mt "$migration_type" \
                  --arg sdb "$source_db" \
                  --arg se "$source_engine" \
                  --arg ss "$source_schema" \
                  --arg sh "$source_host" \
                  --arg su "$source_user" \
                  --arg sp "$source_port" \
                  --arg kn "$key_name" \
                  --arg jnt "$jmeter_node_type" \
                  --arg jkn "$jmeter_key_name" \
                  --arg jm "$jmeter" \
                  '{
                    vpc_id: $bn, 
                    redshift_endpoint: $on, 
                    dms_migration_to_redshift_target: $tl, 
                    jmeter: $jm,
                    vpc:{
                        cidr: $ll,
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
                        jmeter_key_name: $jkn,
                        jmeter_node_type: $jnt
                    }
                    }' \ >user-config.json ) 

echo $JSON_STRING
echo "<----CREATE/NA---->"
echo "vpc ID: "$vpc_id
echo "redshift endpoint: "$redshift_endpoint
echo "dms: " $dms_migration_to_redshift_target
echo "sct: "$sct_on_prem_to_redshift_target
echo "jmeter: " $jmeter
echo "---------------------------"
echo "<----VPC DETAILS---->"
echo "vpc cidr: " $cidr
echo "Number of AZ's: "$number_of_az
echo "CIDR Mask: "$cidr_mask
echo "Existing VPC: " $existing_vpc_id
echo "---------------------------"
echo "<----REDSHIFT DETAILS---->"
echo $"existing_RS_id: " $existing_RS_id
echo "cluster identifer: " $cluster_identifier
echo "redshift database name: "$database_name
echo "redshift master username: "$master_user_name
echo "redshift node type: " $node_type
echo "redshift number of nodes: "$number_of_nodes
echo "redshift subnet type:"$subnet_type
echo "redshift encryption type:"$encryption
echo "redshift load tpc data?: "$loadTPCdata
echo "---------------------------"
echo "<----DMS DETAILS---->"
echo "Source Database: " $source_db
echo "Source Engine: " $source_engine
echo "Source Schema: " $source_schema
echo "Source Host: " $source_host
echo "Source User: " $source_user
echo "Source Port: " $source_port
echo "---------------------------"
echo "<----SCT EC2 KEYNAME--->"
echo "sct key name: "$key_name
echo "---------------------------"
echo "<----Jmeter EC2 KEYNAME--->"
echo "jmeter key name: "$jmeter_key_name
echo "---------------------------"




