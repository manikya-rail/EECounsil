module Api
  module V1
    class StripeWebhooksController < ApplicationController

      def webhook
        begin
            event_json = JSON.parse(request.body.read)
            event_object = event_json['data']['object']
            if event_object["metadata"].include? "package_id"
              if event_json['type']  == "charge.succeeded"
                @patient_package = PatientPackage.new(patient_id: event_object["metadata"]["patient_id"].to_i, package_id: event_object["metadata"]["package_id"].to_i)
                if @patient_package.save
                  Payment.create_payment_details(event_object,0)
                  render status: :ok, json: "success"
                else
                  render json: { message: 'Unable to create patient package' }
                end
              end
              if event_json['type'] == "customer.failed"
                Payment.create_failed_payment(event_object,0)
              end

            elsif event_object["metadata"].include? "course_id"
              if event_json['type']  == "charge.succeeded"
                  @therapist_course = TherapistCourse.new(therapist_id: event_object["metadata"]["therapist_id"].to_i, course_id: event_object["metadata"]["course_id"].to_i)
                  if @therapist_course.save
                    Payment.create_payment_details(event_object,3)
                    render status: :ok, json: "success"
                  else
                    render json: { message: 'Unable to create therapist course' }
                  end
              end
              if event_json['type'] == "customer.failed"
                Payment.create_failed_payment(event_object,3)
              end

            elsif event_json['type'] == 'payout.paid'
              therapist = Therapist.find(event_object["metadata"]['payout_user_id'])
              Schedule.where(therapist_id: therapist.id ,status: 'completed').update(paid_to_therapist: true)
              Payment.payout_paid(event_object)
              UserMailer.success_payout(therapist,event_object['amount']).deliver_now
              render status: :ok, json: "success"

            elsif event_json['type'] == 'payout.failed'
              Payment.payout_paid(event_object)
              render status: :ok, json: "success"
            end

          event_object = event_json['data']['object'] 
          event_object = event_json['object'] if !event_object

          if event_object == "subscription"
            id = event_object["id"]
            status = event_object["status"]
            subscription = Subscription.find_by_stripe_subscription_id(id)
            if subscription
              if status == "incomplete"
                puts "incomplete request required again payment!"
                subscription.status = "locked"
                subscription.save
                render status: :ok, json: "incomplete_subscription"
              elsif status == "trialing"
                puts "incomplete request required again payment!"
                subscription.status = "trialing"
                subscription.save
                render status: :ok, json: "incomplete_subscription"
              elsif status == "active"
                puts "incomplete request required again payment!"
                subscription.status = "active"
                subscription.save
                render status: :ok, json: "incomplete_subscription"
              end
            end
          end


        rescue Exception => ex
          render json: { status: 422, error: "Webhook call failed" }
          return
        end

      end

    end
  end
end
