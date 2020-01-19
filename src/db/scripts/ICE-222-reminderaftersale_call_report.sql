--UPDATE Aftersale tasks name if empty
update call_task as ct set task_name = aht.name_ from act_hi_taskinst as aht where aht.id_ = ct.task_id and aht.name_ = 'Aftersale task';


--ADD Aftersale tasks before update
insert into call_task (created, task_id, comment, option, task_name)
select
aht.end_time_, aht.id_, '', '', 'Aftersale task'
from campaign_client cc
  JOIN act_hi_varinst ahv ON ahv.long_ = cc.id and name_ = 'campaignClientId'
  JOIN act_hi_taskinst aht ON aht.id_ = ahv.task_id_
where
aht.delete_reason_ = 'completed' and aht.assignee_ is not null
and not exists (select * from call_task where task_id = aht.id_);


--ADD Reminder tasks before update
insert into call_task (created, task_id, comment, option, task_name)
select at.end_time_, at.id_, '', '', at.name_
  from act_hi_taskinst at
    left join call_task ct on at.id_ = ct.task_id
  where at.name_ in ('First reminder call', 'Second reminder call', 'Third reminder call', 'Fourth reminder call') and at.assignee_ is not null and at.delete_reason_ = 'completed' and at.end_time_ is not null
    and not exists
    (select * from call_task where task_id = at.id_);