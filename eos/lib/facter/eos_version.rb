# Copyright 2013 Arista Networks
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
cmd = "FastCli -c \"show version\""
cmd_result = Facter::Util::Resolution.exec(cmd)
lines = cmd_result ? cmd_result.split('\n') : []

lines.each do |line|
  next if line.empty?

  k,v = line.split(':')
  if !v.nil?
    k.downcase!
    k.gsub!(' ','_')

    fact_name = "eos_" + k
    Facter.add(fact_name) do
      setcode do
        v.strip
      end
    end
  end
end
