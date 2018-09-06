object @project
cache @project

attributes :id, :name

child :instruments do
  extends 'api/v2/instruments/show'
end
