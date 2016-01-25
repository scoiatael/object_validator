RSpec.describe ObjectValidator do
  validator = described_class.new

  context '#string' do
    schema = {
      type: :string,
      required: true,
      validate: ->(value) { value.split(' ').length == 1 },
      constraints: {
        length: {
          max_length: 5,
          min_length: 2
        },
        blank: false,
        format: /^a.*/
      }
    }

    context 'valid string' do
      before(:all) { validator.validate_object('abc', schema) }

      it { expect(validator.errors).to be_empty }
    end

    context 'invalid string (one failure)' do
      let(:error_msg) { 'It doesn\'t match with a given regular expression.' }

      before(:all) { validator.validate_object('bca', schema) }

      it { expect(validator.errors['self']).to include(error_msg) }
      it { expect(validator.errors['self'].count).to eq(1) }
    end

    context 'invalid string (several failures)' do
      before(:all) { validator.validate_object(' ', schema) }

      let(:error_msg1) { 'It doesn\'t match with a given regular expression.' }
      let(:error_msg2) { 'It can\'t be blank.' }
      let(:error_msg3) { 'It is too short (less than 2 characters).' }
      let(:error_msg4) { 'Custom validation (validate proc) failed.' }

      it { expect(validator.errors['self'].count).to eq(4) }
      it { expect(validator.errors['self']).to include(error_msg1) }
      it { expect(validator.errors['self']).to include(error_msg2) }
      it { expect(validator.errors['self']).to include(error_msg3) }
      it { expect(validator.errors['self']).to include(error_msg4) }
    end

    context 'nil string' do
      before(:all) { validator.validate_object(nil, schema) }

      let(:error_msg1) { 'It doesn\'t match with a given regular expression.' }
      let(:error_msg2) { 'It can\'t be blank.' }
      let(:error_msg3) { 'It is too short (less than 2 characters).' }
      let(:error_msg4) { 'It is too long (more than 5 characters).' }
      let(:error_msg5) { 'It can\'t be nil.' }
      let(:error_msg6) { 'It is not an instance of String.' }
      let(:error_msg7) { 'Custom validation (validate proc) failed.' }

      it { expect(validator.errors['self'].count).to eq(7) }
      it { expect(validator.errors['self']).to include(error_msg1) }
      it { expect(validator.errors['self']).to include(error_msg2) }
      it { expect(validator.errors['self']).to include(error_msg3) }
      it { expect(validator.errors['self']).to include(error_msg4) }
      it { expect(validator.errors['self']).to include(error_msg5) }
      it { expect(validator.errors['self']).to include(error_msg6) }
      it { expect(validator.errors['self']).to include(error_msg7) }
    end

    xcontext 'invalid schema' do
      wrong_schema = { type: :string, constraints: { length: { max_length: 'hello' } } }
      before(:all) { validator.send(:validate_schema!, ['self'], wrong_schema) }
      let(:error_key) { 'self.schema.constraints.length.max_length' }
      let(:error_msg) { 'It is not an instance of Fixnum.' }

      it { expect(validator.errors).not_to be_empty }
      it { expect(validator.errors[error_key]).to include(error_msg) }
    end
  end

  context '#hash' do
    schema = {
      type: :hash,
      constraints: {
        empty: false
      },
      keys: [
        {
          key: :a,
          type: :string,
          required: true,
          constraints: {
            length: {
              value_length: 1
            }
          }
        },
        {
          key: :b,
          type: :string
        }
      ]
    }

    context 'valid hash' do
      map = { a: '1' }
      before(:all) { validator.validate_object(map, schema) }

      it { expect(validator.errors).to be_empty }
    end

    context 'invalid hash (one failure)' do
      map = { a: '1', b: 1 }
      before(:all) { validator.validate_object(map, schema) }
      let(:error_msg) { 'It is not an instance of String.' }

      it { expect(validator.errors).not_to be_empty }
      it { expect(validator.errors['self.b']).to include(error_msg) }
    end

    context 'invalid hash (several failures)' do
      map = { a: '22', b: 1 }
      before(:all) { validator.validate_object(map, schema) }

      let(:error_msg_a) { 'Length is not 1.' }
      let(:error_msg_b) { 'It is not an instance of String.' }

      it { expect(validator.errors).not_to be_empty }
      it { expect(validator.errors['self.a']).to include(error_msg_a) }
      it { expect(validator.errors['self.b']).to include(error_msg_b) }
    end

    xcontext 'invalid schema (several failures)' do
      wrong_schema = { type: :hash, constraints: { size: '1', empty: 1 }, keys: [] }
      before(:all) { validator.send(:validate_schema!, ['self'], wrong_schema) }

      let(:error_key1) { 'self.schema.constraints.size' }
      let(:error_key2) { 'self.schema.constraints.empty' }
      let(:error_msg1) { 'It is not an instance of Hash.' }
      let(:error_msg2) { 'It is not a boolean value.' }

      it { expect(validator.errors).not_to be_empty }
      it { expect(validator.errors[error_key1]).to include(error_msg1) }
      it { expect(validator.errors[error_key2]).to include(error_msg2) }
    end
  end

  context '#array' do
    schema = {
      type: :array,
      required: true,
      ordered: true,
      items: [
        {
          type: :string,
          required: true,
          constraints: {
            format: /^a.*/
          }
        },
        {
          type: :array,
          required: true,
          ordered: true,
          items: [
            {
              required: true,
              type: :string,
              constraints: {
                format: /^a.*/
              }
            },
            {
              type: :string,
              constraints: {
                format: /^b.*/
              }
            }
          ]
        }
      ]
    }

    context 'valid array' do
      before(:all) { validator.validate_object(['a', %w(a b)], schema) }

      it { expect(validator.errors).to be_empty }
    end

    context 'invalid array (one failure)' do
      before(:all) { validator.validate_object(['a', %w(b b)], schema) }
      let(:error_msg) { 'It doesn\'t match with a given regular expression.' }

      it { expect(validator.errors.count).to eq(1) }
      it { expect(validator.errors['self.1.0']).to include(error_msg) }
    end

    context 'invalid array (several failures)' do
      before(:all) { validator.validate_object([%w(b b), 'a'], schema) }
      let(:error_msg1) { 'It is not an instance of String.' }
      let(:error_msg2) { 'It doesn\'t match with a given regular expression.' }
      let(:error_msg3) { 'It is not an instance of Array.' }

      it { expect(validator.errors['self.0']).to include(error_msg1) }
      it { expect(validator.errors['self.0']).to include(error_msg2) }
      it { expect(validator.errors['self.1']).to include(error_msg3) }
    end
  end
end
