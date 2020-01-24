# Variables

variable ssh_label {
  description = "ssh label"
  default     = "anspro1"
}

variable ssh_key {
  description = "ssh public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7tdyXcE+C+CljZY36Fl76j4yg+BvLkBVnqo0zVOn8O3NFxD/LNNwGFAJ+6Q9EByIp6D4vXQNCA2t4YmswzL5oSwEq2X+xMNEcSyH0esHiZF3LwndKxbGMYyJcSXiHCbYBr4mOpmE2DqehhlJ6T7r2+PCUQwGSRuCb2o+6TtEpQevuXzTQmDp9/1JN9BXZc2FFTwULZrYnwGWjeiBgnvnx056cxfY6K+D1h0+1V4fqDbG6VGBMiKt+k8tWnM26e5B9nvFAfic76zdn/wBHQlP6Dr7UQNSdnZC2k2NkeJ1E0wVXKYNdAaf9tWoUlawRyAG+5YFrNYQ8Epifud+JZ6DG8IpL4tPtLKJzKtZheeYE6FnAzjnn1PFgBeXOeVLxa0zxBw7DUihzC6KdXwTvDhMh3GheDDQ15h5boPJCdhTxEGFDQDul/gycv6U1dwaaYZnwaCn0bXZZ+K8kLoAuBttGYWyCV3+jMktYIt70feFL/gtInl49bD0l3Jy0iEYrignmliEP8yd3B13SWPH83o4mpTxZNCt6Q5/roiK9Zw9HlLGz/QJtkfv7JtRliXiP2RacugtvieHJ9Bn5RhutPjGWzWbfUXAYzpQTcnx4Nudn5bFTN81txhzNv7IbdojL4G+zzlVv+RPfhNmWrvVfsNY4bKNn4q7I9ngmaPkU4d+xEw== steve_strutt@uk.ibm.com"
}

variable ssh_notes {
  description = "ssh public key notes"
  default     = "SSH key for remote access to web site"
}

variable vm_count_app {
  default = 2
}
