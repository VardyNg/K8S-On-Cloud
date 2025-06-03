resource "kubernetes_manifest" "eni_config_secondary_1" {

	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind       = "ENIConfig"
		metadata = {
			name = aws_subnet.subnet_secondary_1.availability_zone
		}
		spec = {
			subnet     = aws_subnet.subnet_secondary_1.id
		}
	}
}

resource "kubernetes_manifest" "eni_config_secondary_2" {

	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind       = "ENIConfig"
		metadata = {
			name = aws_subnet.subnet_secondary_2.availability_zone
		}
		spec = {
			subnet     = aws_subnet.subnet_secondary_2.id
		}
	}
}

resource "kubernetes_manifest" "eni_config_secondary_3" {

	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind       = "ENIConfig"
		metadata = {
			name = aws_subnet.subnet_secondary_3.availability_zone
		}
		spec = {
			subnet     = aws_subnet.subnet_secondary_3.id
		}
	}
}
