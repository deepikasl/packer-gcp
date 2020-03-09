export IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]; then
    echo "Need to provide IMAGE_NAME as Input 1"
    exit 1
fi

export PROJECT_ID=$2
if [ -z "$PROJECT_ID" ]; then
    echo "Need to provide PROJECT_ID as Input 2"
    exit 1
fi
export METADATA=$(jq -n '{ "projectName": '"$PROJECT_ID"', "imageName": '"$IMAGE_NAME"' }')
