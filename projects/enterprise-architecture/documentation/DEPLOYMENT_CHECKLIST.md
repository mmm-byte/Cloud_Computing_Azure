# Deployment Checklist

## Pre-Deployment (24 hours before)

- [ ] Code review completed
- [ ] All tests passing in CI pipeline
- [ ] Database migrations tested in staging
- [ ] Performance testing completed
- [ ] Security scan results reviewed
- [ ] Rollback plan documented
- [ ] On-call engineer notified
- [ ] Customer notified if required
- [ ] Monitoring dashboards prepared
- [ ] Runbooks updated

## Deployment Execution

### Planning Phase
- [ ] Deployment window scheduled
- [ ] Change ticket created
- [ ] Team members assigned roles
- [ ] Communication channels open (Slack, Teams)
- [ ] Incident commander identified

### Pre-Deployment Phase
- [ ] Database backup completed
- [ ] Current metrics baseline captured
- [ ] Health checks verified
- [ ] Load balancer health check: PASS
- [ ] Database connectivity: OK
- [ ] Storage account accessibility: OK

### Deployment Phase
- [ ] Git tag created for release
- [ ] Terraform plan reviewed
- [ ] Blue-green slot swap initiated
- [ ] Health probe tests: PASS
- [ ] Application endpoints responding
- [ ] Error rates monitoring: <0.1%
- [ ] Response times normal: <500ms
- [ ] Database queries executing
- [ ] No customer complaints received

### Post-Deployment Phase (30 minutes)
- [ ] Logs reviewed for errors
- [ ] Performance metrics: GREEN
- [ ] Error rate: <0.1%
- [ ] CPU utilization: <60%
- [ ] Memory utilization: <70%
- [ ] Database performance: NORMAL
- [ ] Backup job: SUCCESSFUL
- [ ] All health checks: PASS

### Post-Deployment Phase (2 hours)
- [ ] Customer feedback received
- [ ] No critical issues reported
- [ ] Rollback capability verified (not needed)
- [ ] Release notes published
- [ ] Change ticket closed

## Rollback Decision Matrix

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error Rate | >5% | Immediate rollback |
| Response Time | >2000ms | Investigate, rollback if not improving |
| CPU Utilization | >90% | Monitor, scale if needed |
| Database Errors | >10/min | Investigate, possible rollback |
| Exception Rate | >1% | Investigate, possible rollback |

## Sign-Off

- [ ] Deployment Approved By: _________________
- [ ] Executed By: _________________
- [ ] Validated By: _________________
- [ ] Date: _________________
- [ ] Notes: _________________
