require 'discordrb'
require 'json'


def select_vc_members(event, include_mute, include_deaf)
  vc = event.user.voice_channel
  return [] unless vc
  event.server.voice_states.values
      .select {|x|
        (x.voice_channel.name === vc.name) &&
            (include_mute || !(x.mute || x.self_mute)) &&
            (include_deaf || !(x.deaf || x.self_deaf))
      }.map {|x| "<@" + x.user_id.to_s + ">"}
end

def get_normal_args(event, args)
  include_deaf = args.include?("$vc_all")
  include_mute = args.include?("$vc_undeafened") || include_deaf
  use_vc = args.include?("$vc_unmuted") || include_mute
  use_vc ?
      select_vc_members(event, include_mute, include_deaf) :
      args.select {|x| !x.start_with?("$vc_")}
end

def get_splitted_args(event, args)
  include_deaf = args.include?("$vc_all")
  include_mute = args.include?("$vc_undeafened") || include_deaf
  use_vc = args.include?("$vc_unmuted") || include_mute
  fixed_args = args.select {|x| !x.start_with?("$vc_")}
  chunk_size = (fixed_args.length + 1) >> 1
  if use_vc
    member = select_vc_members(event, include_mute, include_deaf)
    choice = fixed_args
  else
    member = fixed_args.slice(0, chunk_size)
    choice = fixed_args.slice(chunk_size..-1)
  end
  [member, choice]
end


discord_token = ENV['DISCORD_TOKEN']
command_prefix = '.'

bot = Discordrb::Commands::CommandBot.new token: discord_token, prefix: command_prefix

bot.command :usage do |_event, *args|
  "```" +
      command_prefix +
      "choose n name1 name2 name3 ...\n" +
      command_prefix +
      "shuffle name1 name2 name3 ...\n" +
      command_prefix +
      "amida name1 name2 ... nameN result1 result2 ... resultN ...\n" +
      "\n" +
      "name引数列の代わりに使えます \n" +
      " $vc_unmuted    : ×マイクミュート / ×ヘッドフォンミュート\n" +
      " $vc_undeafened : ○マイクミュート / ×ヘッドフォンミュート\n" +
      " $vc_all        : ○マイクミュート / ○ヘッドフォンミュート" +
      "```"
end

bot.command :choose do |_event, *args|
  len = args[0].to_i
  fixed_args = len === 0 ? args : args.slice(1..-1)
  fixed_len = [1, len].max
  members = get_normal_args(_event, fixed_args).shuffle
  fixed_len === 1 ?
      members[0] :
      members[0...fixed_len].join("\n")
end

bot.command :shuffle do |_event, *args|
  members = get_normal_args(_event, args)
  res = members.shuffle.map.with_index {|x, index| "" + (index + 1).to_s + " : " + x}
  res.join("\n")
end

bot.command :amida do |_event, *args|
  data = get_splitted_args(_event, args)
  len = [data[0].length, data[1].length].min
  members = data[0].shuffle.slice(0, len)
  choices = data[1].shuffle.slice(0, len)
  res = members.map.with_index {|x, index| x + " → " + choices[index]}
  res.join("\n")
end

bot.run
