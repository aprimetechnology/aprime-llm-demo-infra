#!/bin/bash

set -eux

# note: we assume a SINGLE cluster result, a SINGLE ecs instance result, a SINGLE ec2 instance result, a SINGLE task result
# if any issues arise, this may need to be tweaked, and these instructions can be followed as a reference
CLUSTER=$(aws ecs list-clusters | jq .clusterArns[0] -r)
ECS_INSTANCE=$(aws ecs list-container-instances --cluster ${CLUSTER} | jq -r .containerInstanceArns[0])
EC2_INSTANCE=$(aws ecs describe-container-instances --cluster ${CLUSTER} --container-instances ${ECS_INSTANCE} | jq -r .containerInstances[0].ec2InstanceId)
TASK=$(aws ecs list-tasks --cluster ${CLUSTER} | jq -r .taskArns[0])

aws ecs execute-command \
    --cluster ${CLUSTER} \
    --task ${TASK} \
    --container text_generation_inference \
    --interactive \
    --command "/bin/bash" \
;
