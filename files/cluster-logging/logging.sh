#!/bin/bash
oc create -f eo-namespace.yaml
oc create -f clo-namespace.yaml
oc create -f eo-og.yaml
oc create -f eo-csc.yaml
oc create -f eo-sub.yaml
oc create -f eo-rbac.yaml
oc create -f cluster-logging-og.yaml
oc create -f cluster-logging-csc.cr.yaml
oc create -f cluster-logging-sub.yaml
oc create -f cluster-logging-resourse.yaml

sleep 60

oc get csv -n openshift-logging
oc get ip -n openshift-logging
oc get catsrc -n openshift-logging
oc get sub -n openshift-logging
oc get og -n openshift-logging

oc get deployments -n openshift-logging
