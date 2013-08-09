Capistrano::Configuration.instance(:must_exist).load do

  def reformat_code(code)
    code.split("\n").map(&:strip).join("; ")
  end

  # Allow parallel execution of rvm and non rvm commands
  def run_rvm_or(command_rvm, command_else = "true")
    parallel do |session|
      command_else = reformat_code(command_else)
      if Capistrano.const_defined?(:RvmMethods)
        # command_with_shell is defined in RvmMethods so rvm/capistrano has to be required first
        command_rvm  = command_with_shell(reformat_code(command_rvm), fetch(:rvm_shell, "bash"))
        rvm_role = fetch(:rvm_require_role, nil)
        if rvm_role # mixed
          session.when "in?(:#{rvm_role})", command_rvm
          session.else command_else
        else # only rvm
          session.else command_rvm
        end
      else # no rvm
        session.else command_else
      end
    end
  end

end
