require 'rubygems'
require 'resque'
require 'resque_jobs'
            
Resque.enqueue(ReadCommentsJob)