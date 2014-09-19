SockJS = require('node-sockjs-client')

JobChangeListener = ->
  @jobList = {}
  return

JobChangeListener::connect = (url)->
  sock = new SockJS(url)
  sock.onmessage = (msg) =>
    data = JSON.parse(msg.data)
    @updateJob(data.job) if data.event == 'job.change'

JobChangeListener::updateJob = (jobData)->
  job = @jobList[jobData.id]
  return if !job
  if job.isVerbose
    lastSentPos = job.lastSentPos || 0
    job.chat.send jobData.output.substring(lastSentPos)
    job.lastSentPos = jobData.output.length - 1
  if jobData.status != 'RUNNING'
    job.setData(jobData)
    delete @jobList[jobData.id]
    job.onfinish() if job.onfinish
    if jobData.status != 'FINISHED'
      job.chat.send "#{job} didn't finish properly. Status #{jobData.status}"

JobChangeListener::addJob = (job) ->
  @jobList[job.data.id] = job

jobChangeListener = new JobChangeListener()

module.exports = jobChangeListener
