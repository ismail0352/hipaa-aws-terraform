## Keeping the URL which I felt were very good and helped for future reference.
# github.com/trussworks/terraform-aws-waf
# https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules

# For reference purpose, Remember actual rules vary with company to company
# Owasp Top 10 rules

###### Examples for creating WAF (Take it as a reference) given below #######

# India Region Condition
resource "aws_wafregional_geo_match_set" "origin_India" {
  name = "origin_India"

  geo_match_constraint {
    type  = "Country"
    value = "IN"
  }
}

# India Region Rule
resource "aws_wafregional_rule" "origin_India_rule" {
  depends_on = [aws_wafregional_geo_match_set.origin_India]
  name = "origin_India_rule"
  metric_name = "originIndiaRule"

  predicate {
    data_id = aws_wafregional_geo_match_set.origin_India.id
    negated = false
    type = "GeoMatch"
  }
}

//resource "aws_wafregional_rule_group" "origin_India_rule_group" {
//  depends_on = [aws_wafregional_rule.origin_India_rule]
//  name = "origin_India_rule_group"
//  metric_name = "originIndiaRuleGroup"
//
//  activated_rule {
//    action {
//      type = "ALLOW"
//    }
//
//    priority = "1"
//    rule_id  = aws_wafregional_rule.origin_India_rule.id
//    type     = "REGULAR"
//  }
//}

resource "aws_wafregional_ipset" "ipset" {
  name = "tfIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = "192.0.7.0/24"
  }
}

resource "aws_wafregional_rule" "ips" {
  name        = "edit-this-name"
  metric_name = "editThisName"

  predicate {
    data_id = aws_wafregional_ipset.ipset.id // Fill this
    negated = false
    type    = "IPMatch"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafregional_byte_match_set" "allowed_hosts" {
  name = "edit-this-with-refernce-to-allowed-hosts-rule"

  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = "badrefer1"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "referer"
    }
  }
}

resource "aws_wafregional_rule" "allowed_hosts" {
  name        = "edit-this-for-allowed-hosts"
  metric_name = "editThisForAllowedHosts"

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.allowed_hosts.id
    negated = true
  }
}

resource "aws_wafregional_byte_match_set" "blocked_path_prefixes" {
  name = "editthisblackpath"

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }

    target_string = "SomeURI"

    # See ByteMatchTuple for possible variable options.
    # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
    positional_constraint = "STARTS_WITH"

    # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
    # extra or non-standard whitespace
    # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
    text_transformation = "COMPRESS_WHITE_SPACE"
  }
}

resource "aws_wafregional_rule" "blocked_path_prefixes" {
  name        = "edit-with-ref-to-block-path-condition"
  metric_name = "editAgainForBlockPathPrefixes"

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.blocked_path_prefixes.id
    negated = false
  }
}

resource "aws_wafregional_web_acl" "testwaf_webacl" {
  # The name or description of the web ACL.
  name = "testwaf-WebACL"

  # The name or description for the Amazon CloudWatch metric of this web ACL.
  metric_name = "testwafWebACL"

  # Configuration block to enable WAF logging.
  //  logging_configuration {
  //    # Amazon Resource Name (ARN) of Kinesis Firehose Delivery Stream
  //    log_destination = module.webacl_supporting_resources.firehose_delivery_stream_arn
  //  }

  # Configuration block with action that you want AWS WAF to take
  # when a request doesn't match the criteria in any of the rules
  # that are associated with the web ACL.
  default_action {
    # Valid values are `ALLOW` and `BLOCK`.
    type = "ALLOW"
  }

  rule {
    priority = 1
    rule_id = aws_wafregional_rule.origin_India_rule.id
    action {
      # Valid values are `ALLOW`, `BLOCK`, and `COUNT`.
      type = "ALLOW"
    }
  }

  rule {
    priority = 2
    rule_id = aws_wafregional_rule.ips.id
    action {
      type = "BLOCK"
    }
  }

  rule {
    priority = 3
    rule_id = aws_wafregional_rule.allowed_hosts.id
    action {
      type = "BLOCK"
    }
  }

  rule {
    priority = 4
    rule_id = aws_wafregional_rule.blocked_path_prefixes.id
    action {
      type = "BLOCK"
    }
  }
}

resource "aws_wafregional_web_acl_association" "alb" {
  resource_arn = module.alb.this_lb_arn # ARN of the ALB
  web_acl_id   = aws_wafregional_web_acl.testwaf_webacl.id
}
