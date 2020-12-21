<# Removes this instance from any target groups associated with the requested ALB #>

param (
    [parameter(mandatory)] [string] $environment)

$instance = Get-EC2InstanceMetaData -Category InstanceId

$elb = Get-ELB2LoadBalancer -Name "VPC10-$environment-LUCEE"
Get-ELB2TargetGroup -LoadBalancerArn $elb.LoadBalancerArn | ForEach-Object {
    
    if ($_.TargetGroupName -like "VPC10-$environment-*-LUCEE") {
    
        $tgh = Get-ELB2TargetHealth -TargetGroupArn $_.TargetGroupArn
    
        foreach ($instances in $tgh.Target) { 
        
            if ($instance -eq $instances.ID) {
                write-host "Removing " $env:COMPUTERNAME from $_.TargetGroupName
                Unregister-ELB2Target -TargetGroupArn $_.TargetGroupArn -Target $instances
           
            }
        }
    }
}
write-host "Waiting for 40 seconds to get past the deregistration delay"
start-Sleep 40
write-host "Done"
