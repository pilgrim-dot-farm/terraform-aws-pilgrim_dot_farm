* We have a somewhat started terraform project.  
* We own the domain in question.
* The corresponding private SSH key is ~/.ssh/pilgrim.farm.
* We want:
    * An EC2 instance in the default vpc on a public subnet.
    * We want an EIP associated with our EC2.
    * The security group should only allow 22 from our public IP.
    * Instance type c7i-flex.large
    * Disk size 32 GB
    * Name pg
* You have the Terraform MCP server with tools that will help you build out.