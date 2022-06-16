class SimpleWorker
  def self.execute
    return unless block_given?
    Thread.new do
      yield
    end
  end
end
